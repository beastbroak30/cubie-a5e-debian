import inspect
import schematizer

print(schematizer.__file__)
print(inspect.signature(schematizer.render))
print(inspect.getdoc(schematizer.render))
