import re
import sys

def increment_version(current_version, version_type):
    # Split the version into major, minor, patch, and beta components
    match = re.match(r'(\d+)\.(\d+)\.(\d+)(\.beta)?', current_version)
    if match:
        major, minor, patch, beta = match.groups()
        major, minor, patch = map(int, (major, minor, patch))
        beta = 1 if beta else 0
    else:
        sys.exit("Error: Invalid version format.")

    # Increment the version according to the specified type
    if version_type == 'major':
        major += 1
        minor = 0
        patch = 0
        beta = 0
    elif version_type == 'minor':
        minor += 1
        patch = 0
        beta = 0
    elif version_type == 'patch':
        patch += 1
        beta = 0
    elif version_type == 'drop_beta':
        beta = 0
    elif version_type == 'next_beta':
        minor += 1
        beta = 1

    # Construct and return the new version string
    if beta:
        return f"{major}.{minor}.{patch}.beta"
    else:
        return f"{major}.{minor}.{patch}"

def replace_version(version_type):
    filename = 'resources/strings/strings.xml'
    
    # Define the pattern to match semantic version numbers followed by an optional ".beta"
    pattern = r'(\d+\.\d+\.\d+(\.beta)?)'
    
    # Read the content of the file
    with open(filename, 'r') as file:
        content = file.read()

    # Find the current version
    match = re.search(pattern, content)
    if match:
        current_version = match.group(1)
        is_beta = bool(match.group(2))
    else:
        sys.exit("Error: No version found in the file.")

    if version_type == 'drop_beta' and not is_beta:
            sys.exit("Error: The current version is not a beta version.")

    if is_beta and version_type != 'drop_beta':
        sys.exit("Error: The current version is beta, the only available action is 'drop_beta'")

    # Calculate the new version
    new_version = increment_version(current_version, version_type)

    # Perform the substitution
    new_content = re.sub(pattern, new_version, content)

    # Write the modified content back to the file
    with open(filename, 'w') as file:
        file.write(new_content)

    sys.stderr.write(f"Successfully updated from version {current_version} to {new_version}\n")
    return new_version

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <version_type> ['major', 'minor', 'patch', 'drop_beta', 'next_beta']")
        sys.exit(1)

    version_type = sys.argv[1]
    if version_type not in ['major', 'minor', 'patch', 'drop_beta', 'next_beta']:
        print("Error: Invalid version type. Use 'major', 'minor', 'patch', 'drop_beta', or 'next_beta'.")
        sys.exit(1)

    new_version = replace_version(version_type)
    sys.stdout.write(new_version)
