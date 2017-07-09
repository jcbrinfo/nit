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

# Test of formal type instantiations over intersections.
#
# Ensure formal type instantiations ignore types unrelated to the formal type.
# Here, the instantiation of `C::E` for `(B and C[X])` must be `X`,
# not `error`, even if requesting `C::E` for `B` makes no sense.
# Likely, the instantiation of `C::T` for `(B and C[X])` must be `Y`.

import core::kernel

class X
end

class Y
end

class B
end

class C[E]

	type T: Y

	fun foo(x: E): E do return x

	fun bar(y: T): T do return y
end

class D[E]
	super B
	super C[E]
end

fun new_d_x: B do return new D[X]

var x = new X
var y = new Y

var d = new_d_x
assert d isa C[X]
assert d.foo(x) == x
assert d.bar(y) == y
