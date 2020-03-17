import argparse
import yaml
from glob import glob
from nested_lookup import nested_lookup
__PLACEHOLDER__ = '# ------------------------------------------------------------ #'

files = glob("charts/**/values.yaml",recursive=False)

for file in files:
    with open(file, 'r') as data_to_load:
        data = yaml.load(data_to_load, Loader=yaml.loader.SafeLoader)
    
    print("# " + file)
    print(__PLACEHOLDER__)
    images = nested_lookup('image', data)
    for image in images:
            registry = ""
            repository = ""
            tag = ""
            if 'registry' in image.keys():
                registry = image['registry']
            if 'repository' in image.keys():
                repository = image['repository']
            if 'tag' in image.keys():
                tag = image['tag']
            print(f'{registry}/{repository}:{tag}')
    print(__PLACEHOLDER__)
