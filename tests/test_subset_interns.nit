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

import core::kernel

subset Natural
	super Int
	isa do return self >= 0
end

redef class Int
	fun as_natural: Natural do return self.as(Natural)
end

0.as(Natural).output_class_name
2.as_natural.output_class_name

assert 4.is_same_instance(4.as(Natural))
assert 5.as(Natural).is_same_instance(5)
assert 6.is_same_instance(6.as_natural)
assert 7.as_natural.is_same_instance(7)

assert 8.is_same_type(8.as(Natural))
assert 9.as(Natural).is_same_type(9)
assert 10.is_same_type(10.as_natural)
assert 11.as_natural.is_same_type(11)

assert 12 == 12.as(Natural)
assert 13.as(Natural) == 13
assert 14 == 14.as_natural
assert 15.as_natural == 15
