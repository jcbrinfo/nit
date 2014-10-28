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

# Extensions to the Nit model for foreign languages.
module doc::model_ext

intrude import model
intrude import model::model_base

# A type described by a text annoted with links.
#
# For use with Nitdoc only.
class MRawType
	super MType

	redef var model: Model

	# The parts that contitute the description of the type.
	var parts: Sequence[MTypePart] = new Array[MTypePart]

	redef fun as_nullable do return self
	redef fun need_anchor do return false
	redef fun resolve_for(mtype, anchor, mmodule, cleanup_virtual) do return self
	redef fun can_resolve_for(mtype, anchor, mmodule) do return true
	redef fun collect_mclassdefs(mmodule) do return new HashSet[MClassDef]
	redef fun collect_mclasses(mmodule) do return new HashSet[MClass]
	redef fun collect_mtypes(mmodule) do return new HashSet[MClassType]
	redef fun to_s do return parts.to_s
end

# A part of a `RawType`.
class MTypePart
	super MEntity

	redef var model: Model

	# The textual content.
	var text: String

	# If known, the related entity.
	var target: nullable MEntity

	redef fun name do return text
	redef fun to_s do return text

	# Return a version of `self` that links to the specified entity.
	fun link_to(target: nullable MEntity): MTypePart do
		return new MTypePart(model, text, target)
	end
end

# The “package” visiblity.
#
# Any visibility roughly equivalent to the default visibility of Java, that is
# private for a collection of modules.
fun package_visibility: MVisibility do return once new MVisibility("package", 2)

# A class kind with no equivalent semantic in Nit.
fun raw_kind(s: String): MClassKind do return new MClassKind(s, false)
