# This file is part of NIT ( http://www.nitlanguage.org ).
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Graphs and basic entities.
module model::graph

import neo4j
import location

# A Neo4j graph.
class NeoGraph
	var all_nodes: SimpleCollection[NeoNode] = new Array[NeoNode]
	var all_edges: SimpleCollection[NeoEdge] = new Array[NeoEdge]

	# How many operation can be executed in one batch?
	private var batch_max_size = 1000

	# Add a relationship between two nodes.
	#
	# Parameters are the same than for the constructor of `NeoEdge`.
	fun add_edge(from: NeoNode, rel_type: String, to: NeoNode) do
		all_edges.add(new NeoEdge(from, rel_type, to))
	end

	# Save the graph using the specified client.
	fun save(client: Neo4jClient) do
		var nodes = all_nodes
		print("Saving {nodes.length} nodes...")
		push_all(client, nodes)
		var edges = all_edges
		print("Saving {edges.length} edges...")
		push_all(client, edges)
	end

	# Save `neo_entities` in the database using batch mode.
	private fun push_all(client: Neo4jClient, neo_entities: Collection[NeoEntity]) do
		var batch = new NeoBatch(client)
		var len = neo_entities.length
		var sum = 0
		var i = 1

		for nentity in neo_entities do
			batch.save_entity(nentity)
			if i == batch_max_size then
				do_batch(batch)
				sum += batch_max_size
				print("\t{sum * 100 / len}% done.")
				batch = new NeoBatch(client)
				i = 1
			else
				i += 1
			end
		end
		do_batch(batch)
	end

	# Execute `batch` and check for errors.
	#
	# Abort if `batch.execute` returns errors.
	private fun do_batch(batch: NeoBatch) do
		var errors = batch.execute
		if not errors.is_empty then
			sys.stderr.write(errors.to_s)
			exit(1)
		end
	end
end

# The project’s graph.
class ProjectGraph
	super NeoGraph

	# The node reperesenting the project.
	#
	# Once the project’s graph is initialized, this node must not be edited.
	var project: NeoNode = new NeoNode

	# Entities by `model_id`.
	var by_id: Map[String, Entity] = new HashMap[String, Entity]

	# Initialize a new project graph using the specified project name.
	#
	# The specified name will label all nodes of the project’s graph.
	init(name: String) do
		project.labels.add(name)
		project.labels.add("MEntity")
		project.labels.add("MProject")
		project["name"] = name
		all_nodes.add(project)

		var root = new RootNamespace(self)
		root.put_in_graph
		by_id[""] = root
	end

	# Request to all nodes in the graph to add their related edges.
	fun put_edges do
		all_edges.add(new NeoEdge(project, "ROOT", by_id[""]))
		for n in all_nodes do
			if n isa Entity then
				n.put_edges
			end
		end
	end
end

# A model’s entity.
#
# In practice, this is the base class of every node in a `ProjectGraph`.
abstract class Entity
	super NeoNode

	# Graph that will embed the entity.
	var graph: ProjectGraph

	# ID of the entity in the model.
	#
	# Is empty for entities without an ID.
	var model_id: String = "" is writable

	# Associated documentation.
	var doc: JsonArray = new JsonArray is writable

	init do
		self.labels.add(graph.project["name"].to_s)
		self.labels.add("MEntity")
	end

	# The short (unqualified) name.
	#
	# May be also set by `full_name=`.
	fun name=(name: String) do
		self["name"] = name
	end

	# The short (unqualified) name.
	fun name: String do
		var name = self["name"]
		assert name isa String
		return name
	end

	# Include the documentation of `self` in the graph.
	protected fun set_mdoc do
		self["mdoc"] = doc
	end

	# The namespace separator of Nit/C++.
	fun ns_separator: String do return "::"

	# The name separator used when calling `full_name=`.
	fun name_separator: String do return ns_separator

	# The full (qualified) name.
	#
	# Also set `name` using `name_separator`.
	fun full_name=(full_name: String) do
		var m: nullable Match = full_name.search_last(name_separator)

		self["full_name"] = full_name
		if m == null then
			name = full_name
		else
			name = full_name.substring_from(m.after)
		end
	end

	# The full (qualified) name.
	fun full_name: String do
		var full_name = self["full_name"]
		assert full_name isa String
		return full_name
	end

	# Set the full name using the current name and the specified parent name.
	fun parent_name=(parent_name: String) do
		self["full_name"] = parent_name + name_separator + self["name"].as(not null).to_s
	end

	# Set the location of the entity in the source code.
	fun location=(location: nullable Location) do
		self["location"] = location
	end

	# Put the entity in the graph.
	#
	# Called by the loader when it has finished to read the entity.
	fun put_in_graph do
		if doc.length > 0 then
			set_mdoc
		end
		graph.all_nodes.add(self)
		if model_id != "" then graph.by_id[model_id] = self
	end

	# Put the related edges in the graph.
	#
	# This method is called on each node by `ProjectGraph.put_edges`.
	#
	# Note: Even at this step, the entity may modify its own attributes and
	# inner entities’ ones because some values are only known once the entity
	# know its relationships with the rest of the graph.
	fun put_edges do end
end

# An entity whose the location is mandatory.
abstract class CodeBlock
	super Entity

	init do
		self["location"] = new Location
	end

	redef fun location=(location: nullable Location) do
		if location == null then
			super(new Location)
		else
			super
		end
	end
end

# A compound.
#
# Usually corresponds to a `<compounddef>` element in of the XML output of
# Doxygen.
abstract class Compound
	super Entity

	# Set the declared visibility (the proctection) of the compound.
	fun visibility=(visibility: String) do
		self["visibility"] = visibility
	end

	# Set the specific kind of the compound.
	fun kind=(kind: String) do
		self["kind"] = kind
	end

	# Declare an inner namespace.
	#
	# Parameters:
	#
	# * `id`: `model_id` of the inner namespace. May be empty.
	# * `name`: string identifying the inner namespace. May be empty.
	fun declare_namespace(id: String, name: String) do end

	# Declare an inner class.
	#
	# Parameters:
	#
	# * `id`: `model_id` of the inner class. May be empty.
	# * `name`: string identifying the inner class. May be empty.
	fun declare_class(id: String, name: String) do end

	# Declare a base compound (usually, a base class).
	#
	# Parameters:
	#
	# * `id`: `model_id` of the base compound. May be empty.
	# * `name`: string identifying the base compound. May be empty.
	# * `prot`: visibility (proctection) of the relationship.
	# * `virt`: level of virtuality of the relationship.
	fun declare_super(id: String, name: String, prot: String, virt: String) do end
end

# An unrecognised compound.
#
# Used to simplify the handling of ignored entities.
class UnknownCompound
	super Compound

	redef fun put_in_graph do end
	redef fun put_edges do end
end

# A namespace.
class Namespace
	super Compound

	# Inner namespaces (IDs).
	#
	# Left empty for the root namespace.
	var inner_namespaces: SimpleCollection[String] = new Array[String]

	init do
		super
		self.labels.add("MGroup")
	end

	redef fun declare_namespace(id: String, name: String) do
		inner_namespaces.add(id)
	end

	redef fun put_edges do
		super
		graph.add_edge(self, "PROJECT", graph.project)
		if self["name"] == self["full_name"] and self["full_name"] != "" then
			# The root namespace does not know its children.
			var root = graph.by_id[""]
			graph.add_edge(self, "PARENT", root)
			graph.add_edge(root, "NESTS", self)
		end
		for ns in inner_namespaces do
			var node = graph.by_id[ns]
			graph.add_edge(node, "PARENT", self)
			graph.add_edge(self, "NESTS", node)
		end
	end
end

# The root namespace of a `ProjectGraph`.
#
# This the only entity in the graph whose `model_id` is really `""`.
# Added automatically at the initialization of a `ProjectGraph`.
class RootNamespace
	super Namespace

	init do
		super
		self["full_name"] = ""
		self["name"] = graph.project["name"]
	end

	redef fun declare_namespace(id: String, name: String) do end
end

# Add `search_last` to `String`.
redef class String
	# Search the last occurence of the text `t`.
	#
	#     assert "bob".search_last("b").from == 2
	#     assert "bob".search_last("bo").from == 0
	#     assert "bob".search_last("ob").from == 1
	#     assert "bobob".search_last("ob").from == 3
	#     assert "bob".search_last("z") == null
	#     assert "".search_last("b") == null
	fun search_last(t: Text): nullable Match do
		var i = length - t.length

		while i >= 0 do
			if substring(i, t.length) == t then
				return new Match(self, i, t.length)
			end
			i -= 1
		end
		return null
	end
end
