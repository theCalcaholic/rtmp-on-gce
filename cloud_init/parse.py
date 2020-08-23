import sys
from jinja2_base64_filters import jinja2_base64_filters
from jinja2 import Environment, Template, PackageLoader

env = Environment(
  loader=PackageLoader('src', '.'),
  extensions=["jinja2_base64_filters.Base64Filters"])

template = env.get_template('cloud-init.yml.jinja')

target_path = "cloud-init.yml"
if len(sys.argv) > 1:
  target_path = sys.argv[1]

with open(target_path, "w") as f:
  f.write(template.render())
