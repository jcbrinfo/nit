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

class NonZero
	super Numeric
	subset do return not is_zero #alt1# subset #alt2# subset do return my_isa

	# Being specific to the subset, this method should not be callable from the
	# membership test.
	fun my_isa: Bool do return not is_zero
end

assert 42 isa NonZero
assert 42 isa nullable NonZero
assert not 0 isa NonZero #alt1# assert 0 isa NonZero
