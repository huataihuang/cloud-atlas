# Python program to explain os.environ object

# importing os module
import os
import pprint

# Get the list of user's
# environment variables
env_var = os.environ

# Print the list of user's
# environment variables
print("User's Environment variable:")
pprint.pprint(dict(env_var), width = 1)
