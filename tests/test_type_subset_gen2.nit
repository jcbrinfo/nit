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

# Second style of specifying type parameter’s bounds of a subset: in the `super` declaration.

import core

class Summable #alt1# class Summable[E: Numeric] #alt2# class Summable[BOOM]
	super SequenceRead[Numeric] #alt3# super SequenceRead[Boom]
	subset do return true

	fun sum(default: E): E do
		if is_empty then return default
		var i = iterator
		var total = i.item
		for x in i do total += x
		return total
	end
end

var arr = [0, 1, 2, 3]
var s = arr.as(
	Summable[Numeric]
)
print(s.sum(0))
