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

import test_type_subset_gen

redef class Summable[E]
	subset do return not_empty and super

	redef fun sum(default: E): E do
		print "redef fun sum"
		return super
	end
end

assert not new Array[Int] isa Summable[Int]
var foo = [3, 2, 1, 0].as(Summable[Numeric])
print(foo.sum(0))
