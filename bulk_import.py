import json
import time
import sys
# pyrefly: ignore [missing-import]
from supabase import create_client, Client

# =====================================================================
# CONFIGURATION
# Replace these with your actual Supabase credentials.
# You can find these in Supabase Dashboard -> Project Settings -> API.
# =====================================================================
SUPABASE_URL = "https://tznyfheygwlhzillxdew.supabase.co"
SUPABASE_SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR6bnlmaGV5Z3dsaHppbGx4ZGV3Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MDQ5MjMzOSwiZXhwIjoyMDk2MDY4MzM5fQ.d2SY35FQvkSNi8EoOufOO67PFWifXRHuIL6ScjdT4rA" # MUST be the secret service_role key, not anon key.

def format_phone(phone: str) -> str:
    """Formats phone number to standard E.164 (+91...) format."""
    clean = "".join(filter(str.isdigit, phone))
    
    # If it's a 10 digit number, prefix it with +91 (India)
    if len(clean) == 10:
        return f"+91{clean}"
    # If it starts with 91 and has 12 digits, prefix with +
    elif len(clean) == 12 and clean.startswith("91"):
        return f"+{clean}"
    # If it already has '+' in original string, keep as is
    elif phone.strip().startswith("+"):
        return phone.strip()
    else:
        return f"+{clean}"

def import_users():
    if "YOUR_SUPABASE" in SUPABASE_URL or "YOUR_SUPABASE" in SUPABASE_SERVICE_ROLE_KEY:
        print("[ERROR] Please edit 'bulk_import.py' and set your real SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY first!")
        sys.exit(1)

    # Initialize admin supabase client
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

    try:
        with open("users_to_create.json", "r") as f:
            users = json.load(f)
    except FileNotFoundError:
        print("[ERROR] 'users_to_create.json' file not found. Please create it first!")
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"[ERROR] Failed to parse 'users_to_create.json': {e}")
        sys.exit(1)

    print(f"Loaded {len(users)} users. Starting import...")

    for idx, user in enumerate(users):
        name = user.get("name")
        raw_phone = user.get("phone")
        role = user.get("role", "field")
        area_id = user.get("assigned_area_id", "RP001")
        area_name = user.get("assigned_area_name", "Khora Village")

        if not name or not raw_phone:
            print(f"[SKIP] Index {idx}: Missing name or phone number.")
            continue

        phone = format_phone(str(raw_phone))
        print(f"[{idx+1}/{len(users)}] Importing {name} ({phone}) as '{role}'...")

        try:
            # 1. Create the user in auth.users
            # This automatically verifies the phone number (no SMS verification code will be sent)
            auth_response = supabase.auth.admin.create_user({
                "phone": phone,
                "phone_confirm": True,
                "user_metadata": {"name": name}
            })
            
            user_id = auth_response.user.id
            print(f"  -> Created in Supabase Auth. User ID: {user_id}")

            # 2. Create the profile row in public.profiles
            supabase.table("profiles").insert({
                "id": user_id,
                "name": name,
                "phone": phone,
                "role": role,
                "assigned_area_id": area_id,
                "assigned_area_name": area_name
            }).execute()

            print(f"  -> Successfully created profile row.")

            # Small delay to avoid hitting rate limits on larger sets
            time.sleep(0.2)

        except Exception as e:
            # Check if user already exists
            err_str = str(e)
            if "already exists" in err_str or "unique_phone" in err_str:
                print(f"  -> [WARNING] User with phone {phone} already exists in database. Skipping.")
            else:
                print(f"  -> [ERROR] Failed to import: {e}")

    print("\nBulk import process finished!")

if __name__ == "__main__":
    import_users()
