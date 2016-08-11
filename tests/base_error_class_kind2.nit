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

import base_error_class_kind

interface IC2
end

abstract class AC2
end

class CC2
end

enum EnC2
end

extern class ExC2
end

class SSet2
	subset
end

redef class SubI
	super IC2
	#alt1# super AC2
	#alt2# super CC2
	#alt3# super EnC2
	#alt4# super ExC2
	#alt16# super SSet2
end

redef class SubA
	super IC2
	super AC2
	super CC2
	#alt5# super EnC2
	#alt6# super ExC2
	#alt17# super SSet2
end

redef class SubC
	super IC2
	super AC2
	super CC2
	#alt7# super EnC2
	#alt8# super ExC2
	#alt18# super SSet2
end

redef class SubEn
	super IC2
	#alt9# super AC2
	#alt10# super CC2
	#alt11# super EnC2
	#alt12# super ExC2
	#alt19# super SSet2
end

redef class SubEx
	super IC2
	#alt13# super AC2
	#alt14# super CC2
	#alt15# super EnC2
	super ExC2
	#alt20# super SSet2
end

# A subset can inherit anything except a subset, and has only one direct parent.
# Futhermore, a subset can be specialized using the `redef` keyword.

redef class SSetI
	#alt21# super SubI
	#alt22# super IC2
	#alt23# super AC2
	#alt24# super CC2
	#alt25# super EnC2
	#alt26# super ExC2
	#alt27# super SSet2
	#alt28# super Object
end

redef class SSetA
	#alt29# super SubA
end

redef class SSetC
	#alt30# super SubC
end

redef class SSetEn
	#alt31# super SubEn
end

redef class SSetEx
	#alt32# super SubEx
end
