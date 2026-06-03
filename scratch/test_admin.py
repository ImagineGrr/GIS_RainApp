import traceback
from supabase import create_client, Client

SUPABASE_URL = "https://tznyfheygwlhzillxdew.supabase.co"
SUPABASE_SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR6bnlmaGV5Z3dsaHppbGx4ZGV3Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MDQ5MjMzOSwiZXhwIjoyMDk2MDY4MzM5fQ.d2SY35FQvkSNi8EoOufOO67PFWifXRHuIL6ScjdT4rA"

def test():
    print("Initializing client...")
    client: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
    
    print("Testing admin.create_user...")
    try:
        res = client.auth.admin.create_user({
            "phone": "+919999900000",
            "phone_confirm": True,
            "user_metadata": {"name": "Test User"}
        })
        print("Successfully created user! Response:")
        print(res)
        
        # Cleanup
        print("Cleaning up test user...")
        client.auth.admin.delete_user(res.user.id)
        print("Cleaned up successfully.")
    except Exception as e:
        print("Failed to create user!")
        print(f"Error type: {type(e)}")
        print(f"Error message: {e}")
        traceback.print_exc()

if __name__ == "__main__":
    test()
