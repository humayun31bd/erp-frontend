import os
import glob

def fix_mojibake(file_path):
    try:
        # Read the doubly-encoded UTF-8 file
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Reverse the mojibake: encode back to windows-1252 (bytes), then decode as utf-8
        try:
            fixed_content = content.encode('windows-1252').decode('utf-8')
        except UnicodeError:
            # If it fails, maybe it wasn't mojibaked or something else went wrong
            return False
            
        # Write it back correctly
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(fixed_content)
        return True
    except Exception as e:
        print(f"Error on {file_path}: {e}")
        return False

# Find all markdown files
files = glob.glob('e:/aiprojects/Zatca_website/**/*.md', recursive=True)
for file in files:
    if fix_mojibake(file):
        print(f"Fixed encoding for {file}")
