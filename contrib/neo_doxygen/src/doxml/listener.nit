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

# Basic SAX listeners.
module doxml::listener

import saxophonit
import model

abstract class DoxmlListener
	super ContentHandler

	protected var locator: nullable SAXLocator = null

	redef fun document_locator=(locator: SAXLocator) do
		self.locator = locator
	end

	protected fun get_bool(atts: Attributes, local_name: String): Bool do
		return get_optional(atts, local_name, "no") == "yes"
	end

	protected fun get_optional(atts: Attributes, local_name: String,
			default: String): String do
		return atts.value_ns("", local_name) or else default
	end

	protected fun get_required(atts: Attributes, local_name: String): String do
		var value = atts.value_ns("", local_name)
		if value == null then
			throw_error("The `{local_name}` attribute is required.")
			return ""
		else
			return value
		end
	end

	# Parse the attributes of a `location` element.
	protected fun get_location(atts: Attributes): Location do
		var location = new Location

		location.path = atts.value_ns("", "bodyfile") or else atts.value_ns("", "file")
		# Doxygen may indicate `[generated]`.
		if "[generated]" == location.path then location.path = null
		var line_start = atts.value_ns("", "bodystart") or else atts.value_ns("", "line") or else null
		if line_start != null then location.line_start = line_start.to_i
		var line_end = atts.value_ns("", "bodyend")
		if line_end != null then location.line_end = line_end.to_i
		var column_start = atts.value_ns("", "column")
		if column_start != null then location.column_start = column_start.to_i
		if location.line_start == location.line_end then
			location.column_end = location.column_start
		end
		return location
	end

	redef fun end_document do
		locator = null
	end

	protected fun throw_error(message: String) do
		var e: SAXParseException

		if locator != null then
			e = new SAXParseException.with_locator(message, locator.as(not null))
		else
			e = new SAXParseException(message)
		end
		e.throw
	end
end

abstract class StackableListener
	super DoxmlListener

	var reader: XMLReader
	var parent: DoxmlListener
	private var root_uri: String = ""
	private var root_local_name: String = ""
	private var depth = 0

	fun listen_until(uri: String, local_name: String) do
		root_uri = uri
		root_local_name = local_name
		depth = 1
		reader.content_handler = self
		locator = parent.locator
	end

	redef fun start_element(uri: String, local_name: String, qname: String,
			atts: Attributes) do
		if uri == root_uri and local_name == root_local_name then
			depth += 1
		end
	end

	redef fun end_element(uri: String, local_name: String, qname: String) do
		if uri == root_uri and local_name == root_local_name then
			depth -= 1
			if depth <= 0 then
				end_reading
				parent.end_element(uri, local_name, qname)
			end
		end
	end

	fun end_reading do
		reader.content_handler = parent
		locator = null
	end
end

class NoopListener
	super StackableListener
end

class TextListener
	super StackableListener

	private var buf: Buffer = new FlatBuffer
	private var sp: Bool = false

	redef fun listen_until(uri: String, local_name: String) do
		buf.clear
		sp = false
		super
	end

	redef fun characters(str: String) do
		if sp then
			if buf.length > 0 then buf.append(" ")
			sp = false
		end
		buf.append(str)
	end

	redef fun ignorable_whitespace(str: String) do
		sp = true
	end

	redef fun to_s do return buf.to_s
end

class DocListener
	super TextListener

	var doc: JsonArray = new JsonArray is writable

	redef fun end_reading do
		super
		doc.add(to_s)
	end
end
