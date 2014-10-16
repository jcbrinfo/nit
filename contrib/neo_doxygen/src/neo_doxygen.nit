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

# Doxygen XML to Neo4j
#
#     neo_doxygen $project_name $xml_output_dir [$neo4j_url]
module neo_doxygen

import model
import doxml

class NeoDoxygen
	var client: Neo4jClient
	var model: ProjectGraph is noinit

	# Generate a graph from the specified project model.
	#
	# Parameters:
	#
	# * `name`: project name.
	# * `dir`: Doxygen XML output directory path.
	fun put_project(name: String, dir: String) do
		model = new ProjectGraph(name)
		var reader = new CompoundFileReader(model)
		# Queue for sub-directories.
		var directories = new Array[String]

		if dir.length > 1 and dir.chars.last == "/" then
			dir = dir.substring(0, dir.length - 1)
		end
		loop
			for f in dir.files do
				var path = dir/f
				if path.file_stat.is_dir then
					directories.push(path)
				else if f.has_suffix(".xml") and f != "index.xml" then
					print "Processing {path}..."
					reader.read(path)
				end
			end
			if directories.length <= 0 then break
			dir = directories.pop
		end
	end

	# Save the graph.
	fun save do
		model.put_edges
		model.save(client)
	end
end

if args.length != 2 and args.length != 3 then
	stderr.write("Usage: {sys.program_name} $project_name $xml_output_dir [$neo4j_url]\n")
	exit(1)
end
var url = "http://localhost:7474"
if args.length >= 3 then
	url = args[2]
end

var neo = new NeoDoxygen(new Neo4jClient(url))
neo.put_project(args[0], args[1])
neo.save
