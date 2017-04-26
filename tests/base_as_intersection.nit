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

# Test of casts to a type intersection.
#
# * Alternative 1 ensures that the merged interfaces do not allow too much.
#   Should trigger compilation errors.
# * Alternatives 2 to 4 ensure that failing casts give a runtime error.

import kernel

class O
	fun foo do 0.output
end

class A
	super O

	fun bar do 1.output
	fun conflict do 4.output
end

class B
	super O

	fun baz do 2.output
	fun conflict do 4.output
end

class D
	super A
	super B

	fun qux do 3.output
end

fun get_o: Object do return new O
fun get_a: Object do return new A
fun get_b: Object do return new B
fun get_d: Object do return new D

get_a.as(O and A).foo #alt1-4#
get_a.as(A and O).foo #alt1-4#
get_a.as(O and A).bar #alt1-4#
get_a.as(A and O).bar #alt1-4#

get_d.as(A and B).foo #alt1-4#
get_d.as(A and B).bar #alt1-4#
get_d.as(A and B).baz #alt1-4#

#alt1# get_d.as(A and B).conflict # Do not skip one of the types.
#alt1# get_d.as(A and B).qux # Do not replace by a common subtype.

#alt2# get_o.as(A and B).foo # Do not skip the cast.
#alt3# get_a.as(A and B).baz # Do not skip one of the types.
#alt4# get_b.as(A and B).baz # Do not skip one of the types.
