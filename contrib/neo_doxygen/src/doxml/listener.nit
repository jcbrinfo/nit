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
import language_specific

abstract class DoxmlListener
	super ContentHandler

	# The language-specific strategies to use.
	var source_language: SourceLanguage

	# The locator setted by calling `document_locator=`.
	protected var locator: nullable SAXLocator = null

	redef fun document_locator=(locator: SAXLocator) do
		self.locator = locator
	end

	protected fun dox_uri: String do return ""

	redef fun start_element(uri: String, local_name: String, qname: String,
			atts: Attributes) do
		super
		if uri != dox_uri then return # None of our business.
		start_dox_element(local_name, atts)
	end

	protected fun start_dox_element(local_name: String, atts: Attributes) do end

	redef fun end_element(uri: String, local_name: String, qname: String) do
		super
		if uri != dox_uri then return # None of our business.
		end_dox_element(local_name)
	end

	protected fun end_dox_element(local_name: String) do end

	protected fun get_bool(atts: Attributes, local_name: String): Bool do
		return get_optional(atts, local_name, "no") == "yes"
	end

	protected fun get_optional(atts: Attributes, local_name: String,
			default: String): String do
		return atts.value_ns(dox_uri, local_name) or else default
	end

	protected fun get_required(atts: Attributes, local_name: String): String do
		var value = atts.value_ns(dox_uri, local_name)
		if value == null then
			throw_error("The `{local_name}` attribute is required.")
			return ""
		else
			return value
		end
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
		super
		if uri == root_uri and local_name == root_local_name then
			depth += 1
		end
	end

	redef fun end_element(uri: String, local_name: String, qname: String) do
		super
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

	protected var buffer: Buffer = new FlatBuffer
	private var sp: Bool = false

	redef fun listen_until(uri: String, local_name: String) do
		buffer.clear
		sp = false
		super
	end

	redef fun characters(str: String) do
		if sp then
			if buffer.length > 0 then buffer.append(" ")
			sp = false
		end
		buffer.append(str)
	end

	redef fun ignorable_whitespace(str: String) do
		sp = true
	end

	# Flush the buffer.
	protected fun flush_buffer: String do
		var s = buffer.to_s

		buffer.clear
		sp = false
		return s
	end

	redef fun to_s do return buffer.to_s
end

# Parse a content of type `LinkedTextType`.
class LinkedTextListener
	super TextListener

	# The read text.
	var linked_text: LinkedText = new LinkedText

	private var refid = ""

	redef fun listen_until(uri: String, local_name: String) do
		linked_text.clear
		refid = ""
		super
	end

	redef fun start_dox_element(local_name: String, atts: Attributes) do
		super
		push_part
		if "ref" == local_name then refid = get_required(atts, "refid")
	end

	redef fun end_dox_element(local_name: String) do
		super
		push_part
		if "ref" == local_name then refid = ""
	end

	private fun push_part do
		var s = flush_buffer

		if not s.is_empty then
			linked_text.push(new LinkedTextPart(s, refid))
		end
	end

	redef fun to_s do return linked_text.to_s
end

class DocListener
	super TextListener

	var doc: JsonArray = new JsonArray is writable

	redef fun end_reading do
		super
		doc.add(to_s)
	end
end

abstract class EntityDefListener
	super StackableListener

	protected var text: TextListener is noinit
	protected var doc: DocListener is noinit
	protected var noop: NoopListener is noinit

	init do
		super
		text = new TextListener(source_language, reader, self)
		doc = new DocListener(source_language, reader, self)
		noop = new NoopListener(source_language, reader, self)
	end

	protected fun entity: Entity is abstract

	redef fun start_dox_element(local_name: String, atts: Attributes) do
		if ["briefdescription", "detaileddescription", "inbodydescription"].has(local_name) then
			doc.doc = entity.doc
			doc.listen_until(dox_uri, local_name)
		else if "location" == local_name then
			entity.location = get_location(atts)
		else
			noop.listen_until(dox_uri, local_name)
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
end
