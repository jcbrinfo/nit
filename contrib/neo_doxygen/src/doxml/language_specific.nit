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

# Handle language-specific parts of the importation.
module doxml::language_specific

import linked_text
import model

# Various importation logics that depend on the project’s language.
abstract class SourceLanguage

	# Apply the information deduced from `type_text` to `member`.
	#
	# `type_text` is the content of the `<type>` element.
	fun apply_member_type(type_text: LinkedText, member: Member) is abstract

	# Extract the specified keyword at the beginning of the specified text.
	#
	# If the keyword is at the beginning of the specified text, return `true`
	# and remove the keyword. Else, return false.
	#
	# Used to extract some keywords that Doxygen puts in the type.
	#
	#     class DummySource
	#     	super JavaSource
	#     #
	#     	fun test(text: LinkedText, keyword: String): Bool do
	#     		return extract_keyword(text, keyword)
	#     	end
	#     end
	#     #
	#     var text = new LinkedText
	#     var dummy = new DummySource
	#     var res: Bool
	#     #
	#     text.push(new LinkedTextPart("abstract final", ""))
	#     res = dummy.test(text, "static")
	#     assert not res
	#     res = dummy.test(text, "abstract")
	#     assert res
	#     assert "final" == text.first.content
	#     res = dummy.test(text, "final")
	#     assert res
	#     assert text.is_empty
	#     res = dummy.test(text, "abstract")
	#     assert not res
	protected fun extract_keyword(text: LinkedText, keyword: String): Bool do
		if text.is_empty then return false
		var content = text.first.content.l_trim
		var refid = text.first.refid
		var found = false

		if "" == refid and content.has_prefix(keyword) then
			if keyword.length == content.length then
				content = ""
				found = true
			else if content.chars[keyword.length] <= ' ' then
				content = content.substring_from(keyword.length).l_trim
				found = true
			end
			if "" == content then
				text.shift
			else if found then
				text[0] = new LinkedTextPart(content, refid)
			end
		end
		return found
	end
end

# Importation logics for Java.
class JavaSource
	super SourceLanguage

	redef fun apply_member_type(type_text, member) do
		# For abstract members, Doxygen put `abstract` at the beginning of the type.
		# We assume that Doxygen do not put annotation in the type (it seems to
		# be the case).
		member.is_abstract = extract_keyword(type_text, "abstract")
		# TODO
	end
end
