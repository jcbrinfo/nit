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

# `compounddef` element reading.
module doxml::compounddef

import listener

class CompoundDefListener
	super StackableListener

	var compound: Compound is writable, noinit
	private var text: TextListener is noinit
	private var doc: DocListener is noinit
	private var noop: NoopListener is noinit
	private var refid = ""
	private var prot = ""
	private var virt = ""

	init do
	text = new TextListener(reader, self)
	doc = new DocListener(reader, self)
	noop = new NoopListener(reader, self)
	end

	redef fun start_element(uri: String, local_name: String, qname: String,
			atts: Attributes) do
		super
		if uri != "" then return # None of our business.
		if ["compoundname", "innerclass", "innernamespace"].has(local_name) then
			text.listen_until(uri, local_name)
			if ["innerclass", "innernamespace"].has(local_name) then
				refid = get_required(atts, "refid")
			end
		else if "basecompoundref" == local_name then
			refid = get_optional(atts, "refid", "")
			prot = get_optional(atts, "prot", "")
			virt = get_optional(atts, "virt", "")
			text.listen_until(uri, local_name)
		else if "location" == local_name then
			compound.location = get_location(atts)
		else if "detaileddescription" == local_name then
			doc.doc = compound.doc
			doc.listen_until(uri, local_name)
		else if local_name != "sectiondef" then
			noop.listen_until(uri, local_name)
		end
	end

	redef fun end_element(uri: String, local_name: String, qname: String) do
		super
		if uri != "" then return # None of our business.
		if local_name == "compounddef" then
			compound.put_in_graph
		else if local_name == "compoundname" then
			compound.full_name = text.to_s
		else if local_name == "innerclass" then
			compound.declare_class(refid, text.to_s)
		else if local_name == "innernamespace" then
			compound.declare_namespace(refid, text.to_s)
		else if local_name == "basecompoundref" then
			compound.declare_super(refid, text.to_s, prot, virt)
		end
	end
end
