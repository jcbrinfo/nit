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

# Test of type tests against intersections.

import kernel

class A
end

class B
end

class D
	super A
	super B
end

fun test_a_and_b(x: Object) do (x isa (A and B)).output
fun get_d: (A and B) do return new D

test_a_and_b(new Object)
test_a_and_b(new A)
test_a_and_b(new B)
test_a_and_b(new D)

'\n'.output

# Should continue to work even when we have more context.
var d = get_d
(d isa (A and B)).output
