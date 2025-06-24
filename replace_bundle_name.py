import os
import sys
import re
import subprocess

def get_bundle_name(location):
    """
    Get the appropriate bundle name based on location parameter.
    """
    if location.lower() == 'sf':
        return "com.dancesf.app"
    elif location.lower() == 'mx':
        return "com.dancemx.app"
    else:
        raise ValueError("Location must be either 'sf' or 'mx'")

def get_app_name(location):
    """
    Get the appropriate app name based on location parameter.
    """
    if location.lower() == 'sf':
        return "Dance SF"
    elif location.lower() == 'mx':
        return "Dance MX"
    else:
        raise ValueError("Location must be either 'sf' or 'mx'")

def get_location_data(location):
    """
    Get the appropriate location data based on location parameter.
    """
    if location.lower() == 'sf':
        return {
            'zone': 'San Francisco',
            'latitude': 37.575431,
            'longitude': -122.161285,
            'locale': 'en'
        }
    elif location.lower() == 'mx':
        return {
            'zone': 'Mexico',
            'latitude': 19.4326,
            'longitude': -99.1332,
            'locale': 'es'
        }
    else:
        raise ValueError("Location must be either 'sf' or 'mx'")

def should_process_file(file_path):
    """
    Determine if a file should be processed based on its path and extension.
    """
    # Skip build directories
    if 'build/' in file_path or '/build/' in file_path:
        return False
        
    # Skip binary and generated files
    ignored_extensions = {
        '.log', '.txt', '.tab', '.tab_i', '.tab.len', '.values.at',
        '.class', '.jar', '.so', '.dylib', '.dll', '.exe',
        '.png', '.jpg', '.jpeg', '.gif', '.ico', '.pdf',
        '.zip', '.tar', '.gz', '.rar', '.7z',
        '.db', '.sqlite', '.sqlite3',
        '.bin', '.dat', '.cache'
    }
    
    return not any(file_path.endswith(ext) for ext in ignored_extensions)

def update_bundle_name(directory, old_bundle, new_bundle):
    """
    Update bundle name in all relevant files within a directory and its subdirectories,
    ignoring binary files and build directories.
    """
    updated_files = {}
    
    for root, dirs, files in os.walk(directory):
        # Skip build directories
        if 'build' in dirs:
            dirs.remove('build')
            
        for file in files:
            file_path = os.path.join(root, file)
            relative_path = os.path.relpath(file_path, directory)
            
            if not should_process_file(relative_path):
                continue
                
            try:
                # Try to read as text first
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    
                if old_bundle in content:
                    # Update content
                    new_content = content.replace(old_bundle, new_bundle)
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    
                    updated_files[relative_path] = True
                    
            except UnicodeDecodeError:
                # Skip binary files
                continue
            except (IsADirectoryError, PermissionError) as e:
                print(f"Error processing {relative_path}: {str(e)}")
                continue
    
    return updated_files

def update_storage_file(directory, location):
    """
    Update the default location data in the storage file.
    """
    storage_file = os.path.join(directory, 'lib', 'utils', 'app_storage.dart')
    if not os.path.exists(storage_file):
        print(f"Warning: Storage file not found at {storage_file}")
        return False

    location_data = get_location_data(location)
    
    try:
        with open(storage_file, 'r', encoding='utf-8') as f:
            content = f.read()

        # Update the default zone
        content = re.sub(
            r'static const defaultZone = \'[^\']+\'',
            f"static const defaultZone = '{location_data['zone']}'",
            content
        )

        # Update the default locale
        content = re.sub(
            r'static const defaultLocale = \'[^\']+\'',
            f"static const defaultLocale = '{location_data['locale']}'",
            content
        )

        # Update the default map center coordinates
        content = re.sub(
            r'latitude: [\d.-]+,\s+longitude: [\d.-]+',
            f"latitude: {location_data['latitude']},\n    longitude: {location_data['longitude']}",
            content
        )

        with open(storage_file, 'w', encoding='utf-8') as f:
            f.write(content)
        
        return True
    except Exception as e:
        print(f"Error updating storage file: {str(e)}")
        return False

def update_launcher_icons(directory, location):
    """
    Update the launcher icons configuration and generate new icons.
    """
    icons_file = os.path.join(directory, 'flutter_launcher_icons.yaml')
    if not os.path.exists(icons_file):
        print(f"Warning: Launcher icons config not found at {icons_file}")
        return False

    try:
        with open(icons_file, 'r', encoding='utf-8') as f:
            content = f.read()

        # Update the image paths
        if location.lower() == 'sf':
            content = re.sub(
                r'image_path: "assets/images/[^"]+"',
                'image_path: "assets/images/sf_dance_icon.png"',
                content
            )
        else:  # mx
            content = re.sub(
                r'image_path: "assets/images/[^"]+"',
                'image_path: "assets/images/mx_dance_icon.png"',
                content
            )

        with open(icons_file, 'w', encoding='utf-8') as f:
            f.write(content)

        # Run flutter pub run flutter_launcher_icons
        print("\nGenerating new launcher icons...")
        result = subprocess.run(
            ['flutter', 'pub', 'run', 'flutter_launcher_icons'],
            cwd=directory,
            capture_output=True,
            text=True
        )
        
        if result.returncode == 0:
            print("Successfully generated new launcher icons")
            return True
        else:
            print(f"Error generating launcher icons: {result.stderr}")
            return False

    except Exception as e:
        print(f"Error updating launcher icons: {str(e)}")
        return False

def update_app_name(directory, location):
    """
    Update the app name in various configuration files.
    """
    new_name = get_app_name(location)
    old_name = "Dance MX" if location.lower() == 'sf' else "Dance SF"
    updated_files = {}

    # Files to update with their patterns
    files_to_update = {
        'android/app/src/main/AndroidManifest.xml': [
            (r'android:label="[^"]+"', f'android:label="{new_name}"')
        ],
        'ios/Runner/Info.plist': [
            # Only update specific app name fields
            (r'<key>CFBundleDisplayName</key>\s*<string>[^<]+</string>', f'<key>CFBundleDisplayName</key>\n\t<string>{new_name}</string>'),
        ],
        'ios/Runner.xcodeproj/project.pbxproj': [
            (r'INFOPLIST_KEY_CFBundleDisplayName = "[^"]+";', f'INFOPLIST_KEY_CFBundleDisplayName = "{new_name}";')
        ],
        'web/index.html': [
            (r'<title>[^<]+</title>', f'<title>{new_name}</title>')
        ]
    }

    for file_path, patterns in files_to_update.items():
        full_path = os.path.join(directory, file_path)
        if not os.path.exists(full_path):
            print(f"Warning: File not found at {full_path}")
            continue

        try:
            with open(full_path, 'r', encoding='utf-8') as f:
                content = f.read()

            original_content = content
            for pattern, replacement in patterns:
                content = re.sub(pattern, replacement, content)

            if content != original_content:
                with open(full_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                updated_files[file_path] = True

        except Exception as e:
            print(f"Error updating {file_path}: {str(e)}")
            continue

    return updated_files

def update_web_and_main_files(directory, location):
    """
    Update web and main files with location-specific content.
    """
    updated_files = {}
    
    # Update web/index.html
    web_file = os.path.join(directory, 'web', 'index.html')
    if os.path.exists(web_file):
        try:
            with open(web_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Update description
            if location.lower() == 'sf':
                content = re.sub(
                    r'<meta name="description" content="[^"]+">',
                    '<meta name="description" content="Find dance events in SF.">',
                    content
                )
            else:  # mx
                content = re.sub(
                    r'<meta name="description" content="[^"]+">',
                    '<meta name="description" content="Find dance events in Mexico.">',
                    content
                )
            
            with open(web_file, 'w', encoding='utf-8') as f:
                f.write(content)
            updated_files['web/index.html'] = True
        except Exception as e:
            print(f"Error updating web/index.html: {str(e)}")
    
    # Update main.dart
    main_file = os.path.join(directory, 'lib', 'main.dart')
    if os.path.exists(main_file):
        try:
            with open(main_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Update title
            if location.lower() == 'sf':
                content = re.sub(
                    r"title: 'Dance in [^']+'",
                    "title: 'Dance in SF'",
                    content
                )
            else:  # mx
                content = re.sub(
                    r"title: 'Dance in [^']+'",
                    "title: 'Dance in MX'",
                    content
                )
            
            with open(main_file, 'w', encoding='utf-8') as f:
                f.write(content)
            updated_files['lib/main.dart'] = True
        except Exception as e:
            print(f"Error updating main.dart: {str(e)}")
    
    return updated_files

def update_verify_screen(directory, location):
    """
    Update the verify screen with location-specific phone number formats.
    """
    verify_file = os.path.join(directory, 'lib', 'screens', 'verify_screen.dart')
    if not os.path.exists(verify_file):
        print(f"Warning: Verify screen file not found at {verify_file}")
        return False

    try:
        with open(verify_file, 'r', encoding='utf-8') as f:
            content = f.read()

        # Update country code and phone number format
        if location.lower() == 'sf':
            # Update country code to +1
            content = re.sub(
                r"TextEditingController\(text: '\+\d+'\)",
                "TextEditingController(text: '+1')",
                content
            )
            # Update country code hint
            content = re.sub(
                r"hintText: '\+52'",
                "hintText: '+1'",
                content
            )
            # Update phone number hint to US format
            content = re.sub(
                r"hintText: '55 1234 5678'",
                "hintText: '234 5323 212'",
                content
            )
        else:  # mx
            # Update country code to +52
            content = re.sub(
                r"TextEditingController\(text: '\+\d+'\)",
                "TextEditingController(text: '+52')",
                content
            )
            # Update country code hint
            content = re.sub(
                r"hintText: '\+1'",
                "hintText: '+52'",
                content
            )
            # Update phone number hint to Mexican format
            content = re.sub(
                r"hintText: '234 5323 212'",
                "hintText: '55 1234 5678'",
                content
            )

        with open(verify_file, 'w', encoding='utf-8') as f:
            f.write(content)
        
        return True
    except Exception as e:
        print(f"Error updating verify screen: {str(e)}")
        return False

def main():
    if len(sys.argv) != 2 or sys.argv[1].lower() not in ['sf', 'mx']:
        print("Usage: python3 find_bundle_name.py [sf|mx]")
        print("  sf: Use com.dancesf.app")
        print("  mx: Use com.dancemx.app")
        sys.exit(1)
        
    mobile_dir = "mobile"
    location = sys.argv[1].lower()
    new_bundle = get_bundle_name(location)
    old_bundle = "com.dancemx.app" if location == "sf" else "com.dancesf.app"
    
    print(f"Updating bundle name from '{old_bundle}' to '{new_bundle}' in {mobile_dir} directory...")
    print("-" * 50)
    
    updated_files = update_bundle_name(mobile_dir, old_bundle, new_bundle)
    
    # Update storage file
    if update_storage_file(mobile_dir, location):
        print("\nUpdated default location data in app_storage.dart")
    
    # Update launcher icons
    if update_launcher_icons(mobile_dir, location):
        print("\nUpdated launcher icons configuration and generated new icons")
    
    # Update app name
    app_name_files = update_app_name(mobile_dir, location)
    if app_name_files:
        print("\nUpdated app name in the following files:")
        for file_path in sorted(app_name_files.keys()):
            print(f"- {file_path}")
    
    # Update web and main files
    web_main_files = update_web_and_main_files(mobile_dir, location)
    if web_main_files:
        print("\nUpdated web and main files:")
        for file_path in sorted(web_main_files.keys()):
            print(f"- {file_path}")
    
    # Update verify screen
    if update_verify_screen(mobile_dir, location):
        print("\nUpdated verify screen with location-specific phone number format")
    
    if updated_files:
        print(f"\nUpdated {len(updated_files)} files:")
        for file_path in sorted(updated_files.keys()):
            print(f"- {file_path}")
    else:
        print(f"No files found containing '{old_bundle}'")

if __name__ == "__main__":
    main() 