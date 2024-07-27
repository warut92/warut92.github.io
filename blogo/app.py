import os
import re

def get_first_hash_string(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        for line in file:
            if line.startswith('#'):
                return line.lstrip('#').strip()
    return None

def extract_six_digit_number(filename):
    match = re.search(r'\d{6}', filename)
    return match.group(0) if match else None

def contains_thai(text):
    return re.search(r'[\u0E00-\u0E7F]', text) is not None

# Get the list of all files and directories in the current directory
files_and_directories = os.listdir()

# Filter out only markdown files (excluding directories and index.md)
markdown_files = [f for f in files_and_directories if os.path.isfile(f) and f.endswith('.md') and f != 'index.md']

# Prepare markdown content
markdown_content = '''<link rel="stylesheet" href="https://warut92.github.io/stilo.css">

# 🖧 Blogejo de Warut

Bonvenon al la mia blogejo. Jen estas miaj artikoloj.\n\n'''

thai_content = "## ภาษาไทย\n\n"
esperanto_content = "## Esperanto\n\n"

for file in markdown_files:
    first_hash_string = get_first_hash_string(file)
    six_digit_number = extract_six_digit_number(file)
    link_text = f'- [{first_hash_string}]({file})' if first_hash_string else f'[{file}]({file})'
    if six_digit_number:
        link_text += f' - [{six_digit_number}]'
    
    link_text += '\n'

    if contains_thai(first_hash_string or ''):
        thai_content += link_text
    else:
        esperanto_content += link_text

# Combine the Thai and esperanto content
markdown_content += esperanto_content + thai_content 

# Write the markdown content to index.md
with open('index.md', 'w', encoding='utf-8') as md_file:
    md_file.write(markdown_content)

print("Markdown content has been written to index.md")
