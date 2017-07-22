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

# Test of the generic susbets regarding type tests and method calls.
#
# Also tests type parameters bounded with by a subset.

import core::kernel

abstract class Foo[E]
	var x: E
end

class ConcreteFoo[E]
	super Foo[E]
end

class ByteFoo
	super Foo[Byte]
end

subset Natural
	super Int
	isa do return self >= 0
end

subset Bar[E: Numeric] #alt1#
#alt1# subset Bar[E: Natural]
	super Foo[E]
	isa do return true

	fun qux(factor: E): E do
		return (x * factor - 1).as(E)
	end
end

# A subclass of `Foo` which intersection with `Bar` is empty.
#
# Used to test if the compiler crash while trying to collect method definitons
# that are relevant to the instances of `CharFoo` or while building its method
# table.
class CharFoo
	super Foo[Char]
end

assert (new ByteFoo(42u8)) isa Bar[Numeric] #alt1#
assert not (new ConcreteFoo[Int](42)) isa Bar[Natural]

var foo = new ConcreteFoo[Natural](42.as(Natural))
assert foo isa Bar[Natural]
assert foo.qux(2.as(Natural)) == 83

# Force `CharFoo` to be live.
assert not (new CharFoo('x') isa Bar[Natural])
