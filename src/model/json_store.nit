# This file is part of NIT ( http://www.nitlanguage.org ).
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Serialization of the model in JSON.
module model::json_store

intrude import neo
import neo4j::json_store

# Adds methods for JSON serialization of the model.
redef class Model
	super Jsonable

	# Retrieve the model from a JSON script.
	#
	# The model is first deserialized using `JsonGraph`, then the resulting
	# graph is translated into a model using `NeoModel`. This is the reverse
	# operation of `to_json`.
	init from_json(t: Text) do
		var g = new JsonGraph.from_json(t)
		
	end

	# Get the JSON representation of `self`.
	#
	# The model is first translated into a graph using `NeoModel`, then it
	# is serialized using `JsonGraph`.
	redef fun to_json do
	end
end
