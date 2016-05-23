import saxophonit
import testing


var proc = new XophonReader
var filter = new SAXEventLogger
var dummy = new SAXEventLogger

filter.parent = proc
filter.parse(new InputSource.with_stream(sys.stdin))
print dummy.diff(filter)
