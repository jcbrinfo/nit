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

# Typing and parameters.
module model::type_entity

import graph
import linked_text

# Base class of all types and signatures.
abstract class TypeEntity
	super Entity

	init do
		super
		self.labels.add("MType")
	end
end

# The bound of a type parameter of a generic class.
#
# Note : The class relationship and the rank are set by `MClassType.put_edges`.
class TypeParameter
	super TypeEntity

	init do
		super
		self.labels.add("MParameterType")
		self["rank"] = -1
	end

	# Specify the rank (index) of the parameter in the signature.
	#
	# Called by `ClassType.put_edges`.
	fun rank=(rank: Int) do
		self["rank"] = rank
	end
end


# A type described by a text.
class RawType
	super TypeEntity
	super LinkedText

	init do
		super
		self.labels.add("MRawType")
	end

	redef fun create_link(rank, refid) do return new TypeLink(graph, refid)
end

# A link in a `RawType`.
class TypeLink
	super Link

	init do
		super
		self.labels.add("MTypePart")
	end
end


# A method’s signature.
class Signature
	super TypeEntity

	var parameters = new Array[Parameter]
	var return_type: nullable TypeEntity = null is writable

	init do
		super
		self.labels.add("MSignature")
	end

	redef fun put_in_graph do
		super
		if return_type isa TypeEntity then
			return_type.as(TypeEntity).put_in_graph
		end
		for p in parameters do
			p.put_in_graph
		end
	end

	redef fun put_edges do
		super
		if parameters.length > 0 then
			var names = new JsonArray
			var p: Parameter

			for i in [0..parameters.length[ do
				p = parameters[i]
				p.rank = i
				names.add(p.name)
				graph.add_edge(self, "PARAMETER", p)
			end
			self["parameter_names"] = names
		end
		if return_type != null then
			graph.add_edge(self, "RETURNTYPE", return_type.as(not null))
		end
	end
end

# A method’s parameter.
class Parameter
	super Entity

	# The static type of the parameter.
	var static_type: nullable TypeEntity = null is writable

	init do
		super
		self.labels.add("MParameter")
		self["is_vararg"] = false
		self["rank"] = -1
	end

	fun is_vararg=(is_vararg: Bool) do
		self["is_vararg"] = is_vararg
	end

	fun is_vararg: Bool do
		var value = self["is_vararg"]
		assert value isa Bool
		return value
	end

	# Specify the rank (index) of the parameter in the signature.
	#
	# Called by `Signature.put_edges`.
	private fun rank=(rank: Int) do
		self["rank"] = rank
	end

	redef fun put_in_graph do
		super
		if static_type != null then
			static_type.as(not null).put_in_graph
		end
	end

	redef fun put_edges do
		super
		graph.add_edge(self, "TYPE", static_type.as(not null))
	end
end
