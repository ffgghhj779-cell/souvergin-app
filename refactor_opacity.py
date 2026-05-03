import os
import re
import glob

def refactor_opacity():
    # Find all dart files in lib
    files = glob.glob('lib/**/*.dart', recursive=True)
    count = 0
    for file in files:
        with open(file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # We want to replace .withOpacity(x) with .withValues(alpha: x)
        # x is usually a number/decimal or dynamic value, e.g. .withOpacity(0.5) or .withOpacity(opacity)
        # Regex: \.withOpacity\((.*?)\)
        # Replacement: .withValues(alpha: \1)
        
        new_content, num_subs = re.subn(r'\.withOpacity\((.*?)\)', r'.withValues(alpha: \1)', content)
        
        if num_subs > 0:
            with open(file, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"Updated {file} ({num_subs} replacements)")
            count += num_subs
    print(f"Total replacements: {count}")

if __name__ == '__main__':
    refactor_opacity()
