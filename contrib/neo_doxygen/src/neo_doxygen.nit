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

# Doxygen XML to Neo4j.
#
# Converts a Doxygen XML output into a model in Neo4j that is readable by the
# `nx` tool.
module neo_doxygen

import model
import doxml
import console
import opts

# An importation task.
class NeoDoxygenJob
	var client: Neo4jClient
	var model: ProjectGraph is noinit

	# Generate a graph from the specified project model.
	#
	# Parameters:
	#
	# * `name`: project name.
	# * `dir`: Doxygen XML output directory path.
	# * `source`: The language-specific logics to use.
	fun load_project(name: String, dir: String, source: SourceLanguage) do
		model = new ProjectGraph(name)
		# TODO Let the user select the language.
		var reader = new CompoundFileReader(source, model)
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

# The main class.
class NeoDoxygenCommand

	# Invalid arguments
	var e_usage = 64

	# Available options for `--src-lang`.
	var sources = new HashMap[String, SourceLanguage]

	# The synopsis.
	var synopsis: String = "[--dest <url>] [--src-lang <lang>]\n" +
			"    [--] <project_name> <doxml_dir>"

	# The synopsis for the help page.
	var help_synopsis = "[-h|--help]"

	# The default destination.
	var default_dest = "http://localhost:7474"

	# Processes the options.
	var option_context = new OptionContext

	# The `--src-lang` option.
	var opt_src_lang: OptionEnum is noinit

	# The `--dest` option.
	var opt_dest: OptionString is noinit

	# The `-h|--help` option.
	var opt_help: OptionBool is noinit

	init do
		sources["any"] = new DefaultSource
		sources["java"] = new JavaSource

		var prefix = new OptionText("""
{{{"NAME".bold}}}
  {{{sys.program_name}}} — Doxygen XML to Neo4j.

{{{"SYNOPSIS".bold}}}
  {{{sys.program_name}}} {{{synopsis}}}
  {{{sys.program_name}}} {{{help_synopsis}}}

{{{"DESCRIPTION".bold}}}
  Convert a Doxygen XML output into a model in Neo4j that is readable by the
  `nx` tool.

{{{"ARGUMENTS".bold}}}
  <project_name>  The internal name of the project. Must the same name as the
                  one specified to the `nx` tool. Must not begin by an upper-
                  case letter.

  <doxml_dir>     The directory where the XML documents generated by Doxygen are
                  located.

{{{"OPTIONS".bold}}}
""")
		option_context.add_option(prefix)

		opt_dest = new OptionString("The URL of the destination graph. `{default_dest}` by default.",
				"--dest")
		opt_dest.default_value = default_dest
		option_context.add_option(opt_dest)

		var keys = new Array[String].from(sources.keys)
		opt_src_lang = new OptionEnum(keys,
				"The programming language to assume when processing chunk in the declarations left as-is by Doxygen. Use `any` (the default) to disable any language-specific processing.",
				keys.index_of("any"), "--src-lang")
		option_context.add_option(opt_src_lang)

		opt_help = new OptionBool("Show the help (this page).",
				"-h", "--help")
		option_context.add_option(opt_help)
	end

	# Start the application.
	fun main: Int do
		if args.is_empty then
			show_help
			return e_usage
		end
		option_context.parse(args)

		var errors = option_context.get_errors
		var rest = option_context.rest

		if errors.is_empty and not opt_help.value and rest.length != 2 then
			errors.add "Unexpected number of additional arguments. Expecting 2; got {rest.length}."
		end
		if not errors.is_empty then
			for e in errors do print_error(e)
			show_usage
			return e_usage
		end
		if opt_help.value then
			show_help
			return 0
		end

		var source = sources[opt_src_lang.value_name]
		var dest = opt_dest.value
		var project_name = rest[0]
		var dir = rest[1]
		var neo = new NeoDoxygenJob(new Neo4jClient(dest or else default_dest))

		neo.load_project(project_name, dir, source)
		neo.save
		return 0
	end

	# Show the help.
	fun show_help do
		option_context.usage
	end

	# Show the usage.
	fun show_usage do
		sys.stderr.write "Usage: {sys.program_name} {synopsis}\n"
		sys.stderr.write "For details, run `{sys.program_name} --help`.\n"
	end

	# Print an error.
	fun print_error(e: String) do
		sys.stderr.write "{sys.program_name}: {e}\n"
	end
end

# Add handling of multi-line descriptions.
#
# Note: The algorithm is naive and do not handle internationalisation and
# escape sequences.
redef class Option

	redef fun pretty(off) do
		var s = super

		if s.length > 80 and off < 80 then
			var column_length = 80 - off
			var left = 0
			var right = 80
			var buf = new FlatBuffer
			var prefix = "\n{" " * off}"

			loop
				while right > left and s.chars[right] != ' ' do
					right -= 1
				end
				if left == right then
					buf.append s.substring(left, column_length)
					right += column_length
				else
					buf.append s.substring(left, right - left)
					right += 1
				end
				buf.append prefix
				left = right
				right += column_length
				if right >= s.length then break
			end
			buf.append s.substring_from(left)
			buf.append "\n"
			return buf.to_s
		else
			return "{s}\n"
		end
	end
end

exit((new NeoDoxygenCommand).main)
