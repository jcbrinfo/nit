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

import kernel

class A
end

class B
	super A
end

class C
	super A
end

class D
	super B
	super C
end

class S1
	super A
	subset do return true
	fun mro1: String do return "S1A"
	fun foo: Int do return 2
end

redef class S1
	super B
	redef fun mro1 do return "S1B," + super
	redef fun foo do return 3 * super
end

redef class S1
	super C
	redef fun mro1 do return "S1C," + super
	redef fun foo do return 5 * super
end

redef class S1
	super D
	redef fun mro1 do return "S1D," + super
	redef fun foo do return 7 * super
end

class S2
	super S1
	subset do return true
	fun mro2: String do return "S2A," + mro1
	fun bar: Int do return 11 * foo
end

redef class S2
	super B #alt1# super A
	redef fun mro2 do return "S2B," + super
	redef fun bar do return 13 * super
end

redef class S2
	super C
	redef fun mro2 do return "S2C," + super
	redef fun bar do return 17 * super
end

redef class S2
	super D
	redef fun mro2 do return "S2D," + super
	redef fun bar do return -1 * super
end

var a: S2 = new A
var b: S2 = new B
var c: S2 = new C
var d: S2 = new D

assert a.mro1 == "S1A"
assert b.mro1 == "S1B,S1A"
assert c.mro1 == "S1C,S1A"
assert d.mro1 == "S1D,S1B,S1C,S1A"
assert a.foo == 2
assert b.foo == 6
assert c.foo == 10
assert d.foo == 210

assert a.mro2 == "S2A,S1A"
assert b.mro2 == "S2B,S2A,S1B,S1A"
assert c.mro2 == "S2C,S2A,S1C,S1A"
assert d.mro2 == "S2D,S2B,S2C,S2A,S1D,S1B,S1C,S1A"
assert a.bar == 22
assert b.bar == 858
assert c.bar == 1870
assert d.bar == -510510
