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

import test_subset_gen2

# Test of the refinement of generic subsets.

redef class Foo
	fun y: Bool do return false
end

class Baz[E]
	super ConcreteFoo[E]

	redef fun y do return true
end

redef subset Bar
	redef isa do return y and super

	redef fun qux(default: E): E do
		'r'.output
		return super
	end
end

var foo = new ConcreteFoo[Int](42)
assert not foo isa Bar[Numeric]

var baz = new Baz[Int](42)
assert baz isa Bar[Numeric]
assert baz.qux(5) == 209
