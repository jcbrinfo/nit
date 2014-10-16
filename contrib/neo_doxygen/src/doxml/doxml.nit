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

# Doxygen’s XML documents reading.
module doxml

import listener
import compounddef

# Reader for XML documents whose the schema is `compound.xsd`.
class CompoundFileReader
	super DoxmlListener

	var model: ProjectGraph
	private var reader: XMLReader = new XophonReader
	private var compoundDef: CompoundDefListener is noinit
	private var noop: NoopListener is noinit

	init do
		compoundDef = new CompoundDefListener(reader, self)
		noop = new NoopListener(reader, self)
	end

	fun read(path: String) do
		reader.content_handler = self
		reader.parse_file(path)
		compoundDef.compound = new UnknownCompound(model)
	end

	redef fun start_element(uri: String, local_name: String, qname: String,
			atts: Attributes) do
		if uri != "" then return # None of our business.
		if local_name == "compounddef" then
			read_compound(atts)
		else if "doxygen" != local_name then
			noop.listen_until(uri, local_name)
		end
	end

	private fun read_compound(atts: Attributes) do
		var kind = atts.value_ns("", "kind").as(not null)

		create_compound(kind)
		# TODO Fit `kind` and `visibility` into the Nit meta-model.
		if get_bool(atts, "final") then
			kind = "final {kind}"
		end
		if get_bool(atts, "sealed") then
			kind = "sealed {kind}"
		end
		if get_bool(atts, "abstract") then
			kind = "abstract {kind}"
		end
		compoundDef.compound.kind = kind
		compoundDef.compound.model_id = atts.value_ns("", "id").as(not null)
		compoundDef.compound.visibility = atts.value_ns("", "prot") or else ""
	end

	private fun create_compound(kind: String) do
		if kind == "file" then
			compoundDef.compound = new FileCompound(model)
		else if kind == "namespace" then
			compoundDef.compound = new Namespace(model)
		else if kind == "class" or kind == "interface" then
			compoundDef.compound = new ClassCompound(model)
		else
			compoundDef.compound = new UnknownCompound(model)
			noop.listen_until("", "compounddef")
			return
		end
		compoundDef.listen_until("", "compounddef")
	end
end
