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

# Tests of autoboxing for call to predicates of formal types.

import core::kernel

subset Even
	super Numeric
	isa do return self.to_i % 2 == 0
end

subset EvenByte
	super Byte
	isa do return self.to_i % 2 == 0
end

class Foo[T: Object]
	fun object_isa_t(x: Object): Bool do return x isa T
	fun byte_isa_t(x: Byte): Bool do return x isa T
end

var foo = new Foo[Even]
var foo_byte = new Foo[EvenByte]

assert foo.byte_isa_t(42.to_b)
assert not foo.byte_isa_t(21.to_b)
assert foo_byte.object_isa_t(42.to_b)
assert not foo_byte.object_isa_t(21.to_b)
