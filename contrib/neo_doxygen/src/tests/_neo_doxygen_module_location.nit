intrude import model::module_compound

var graph = new ProjectGraph("foo")
var file = new FileCompound(graph)

file.name = "QUX.PF"
file.declare_namespace("", "bar")
assert file.inner_namespaces[0]["location"] isa Location
