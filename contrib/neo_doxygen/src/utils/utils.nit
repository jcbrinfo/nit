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

# Various extentions to `standard`.
module utils

# Add `search_last` to `String`.
redef class String
	# Search the last occurence of the text `t`.
	#
	#     assert "bob".search_last("b").from == 2
	#     assert "bob".search_last("bo").from == 0
	#     assert "bob".search_last("ob").from == 1
	#     assert "bobob".search_last("ob").from == 3
	#     assert "bob".search_last("z") == null
	#     assert "".search_last("b") == null
	fun search_last(t: Text): nullable Match do
		var i = length - t.length

		while i >= 0 do
			if substring(i, t.length) == t then
				return new Match(self, i, t.length)
			end
			i -= 1
		end
		return null
	end
end

# A map with a default value.
class DefaultMap[K: Object, V]
	super HashMap[K, V]

	# The default value.
	var default: V

	redef fun provide_default_value(key) do return default
end
