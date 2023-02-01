import argparse
import datetime
import json
import os
import sys

from faker import Faker
from jinja2 import Environment, FileSystemLoader


def nullify(elements):
    nullified = []

    for element in elements:
        if element is None:
            nullified.append('NULL')
        else:
            nullified.append(element)

    return nullified


def quotify(elements):
    quotified = []

    for element in elements:
        if type(element) == str:
            element = element.replace('\'', '\'\'')
            quotified.append(f'\'{element}\'')
        else:
            quotified.append(element)

    return quotified


class DTEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, datetime.date):
            return obj.strftime('%Y-%m-%d')
        return json.JSONEncoder.default(self, obj)


def main(template: str, count: int, datafiles: str, output: str):
    template_dir = os.path.dirname(template)
    template_file = os.path.basename(template)

    environment = Environment(loader=FileSystemLoader(template_dir))

    environment.globals['datetime'] = datetime
    environment.globals['fake'] = Faker()
    environment.globals['sys'] = sys
    environment.globals['DTEncoder'] = DTEncoder

    environment.filters['nullify'] = nullify
    environment.filters['quotify'] = quotify

    data = {}

    if datafiles is not None:
        for datafile in datafiles.split(','):
            file = open(datafile)
            data = data | json.load(file)

    template = environment.get_template(template_file)
    content = template.render(count=count, data=data)

    if output is None:
        output = template_file.replace('.jinja2', '')

    with open(output, mode='w', encoding='utf-8') as file:
        file.write(content)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()

    parser.add_argument('template', type=str)
    parser.add_argument('--count', type=int, default=1)
    parser.add_argument('--data', type=str)
    parser.add_argument('--output', type=str)

    args = parser.parse_args()

    main(args.template, args.count, args.data, args.output)
