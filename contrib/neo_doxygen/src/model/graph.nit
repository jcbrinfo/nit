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

	fun add_edge(from: NeoNode, rel_type: String, to: NeoNode) do
		all_edges.add(new NeoEdge(from, rel_type, to))
	end

	# Save the graph.
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

	var project: NeoNode = new NeoNode

	# Entities by `model_id`.
	var by_id: Map[String, Entity] = new HashMap[String, Entity]

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

	fun put_edges do
		all_edges.add(new NeoEdge(project, "ROOT", by_id[""]))
		for n in all_nodes do
			if n isa Entity then
				n.put_edges
			end
		end
	end
end

abstract class Entity
	super NeoNode

	# Graph that will embed the entity.
	var graph: ProjectGraph

	# ID of the entity in the model.
	#
	# Is empty for entities without ID.
	var model_id: String = "" is writable

	# Associated documentation.
	var doc: JsonArray = new JsonArray is writable

	init do
		self.labels.add(graph.project["name"].to_s)
		self.labels.add("MEntity")
	end

	fun name=(name: String) do
		self["name"] = name
	end

	# Put the entity in the graph.
	fun put_in_graph do
		if doc.length > 0 then
			set_mdoc
		end
		graph.all_nodes.add(self)
		if model_id != "" then graph.by_id[model_id] = self
	end

	# Put the related edges in the graph.
	fun put_edges do end

	# Include the documentation of `self` in the graph.
	protected fun set_mdoc do
		self["mdoc"] = doc
	end
end

# An entity with a full name.
abstract class QEntity
	super Entity

	fun ns_separator: String do return "::"
	fun name_separator: String do return ns_separator

	fun full_name=(full_name: String) do
		var m: nullable Match = full_name.search_last(name_separator)

		self["full_name"] = full_name
		if m == null then
			name = full_name
		else
			name = full_name.substring_from(m.after)
		end
	end

	fun location=(location: nullable Location) do
		self["location"] = location
	end
end

# An entity where the location is mandatory.
abstract class CodeBlock
	super Entity

	init do
		self["location"] = new Location
	end

	fun location=(location: nullable Location) do
		if location == null then
			super(new Location)
		else
			super
		end
	end
end

abstract class Compound
	super QEntity

	fun visibility=(visibility: String) do
		self["visibility"] = visibility
	end

	fun kind=(kind: String) do
		self["kind"] = kind
	end

	# Declare a inner namespace.
	fun declare_namespace(id: String, name: String) do end

	fun declare_class(id: String, name: String) do end

	fun declare_super(id: String, name: String, prot: String, virt: String) do end
end

# Entité composite de type inconnu.
#
# Utilisé pour simplifier le traitement des entités à ignorer.
class UnknownCompound
	super Compound

	redef fun put_in_graph do end
	redef fun put_edges do end
end

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

class RootNamespace
	super Namespace

	init do
		super
		self["full_name"] = ""
		self["name"] = graph.project["name"]
	end

	redef fun declare_namespace(id: String, name: String) do end
end

redef class String
	# Search the last occurence of the text `t`.
	#
	#     assert "bob".search_last("b").from == 2
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