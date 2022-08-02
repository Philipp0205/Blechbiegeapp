# Blechbiege App

Work in progress... 

# Hive Database 

## Generate Adapter
1. To generate a TypeAdapter for a class, annotate it with @HiveType and provide a typeId (between 0 and 223)
2. Annotate all fields which should be stored with @HiveField
3. Run flutter build task `flutter packages pub run build_runner build`
4. Register the generated adapter

[Source](https://docs.hivedb.dev/#/custom-objects/generate_adapter)

## Save git credentials locally 
To store your credentials in cache and avoid logging in every time you perform a git action, follow these steps:

1. Navigate to your local repository folder.
2. In the current folder's terminal: git config --global --replace-all credential.helper cache
3. Perform git push or git pull.
4. Login with username and access token (access token is your password). The token can be setup in GitHub and have access to repo, workflow, write:packages and delete:packages.
5. Repeat git push or any git action and you'll find that it doesn't ask for login credentials from now on.

[Source](https://stackoverflow.com/a/69559900/7127837)

 
# Automatic determination bending sequence
The goal is it to have an automatic determination of the bending sequence of the metal sheet.

Therefore the following technique are applied: 
1. Reverse the tree: Start with the folded product and unfold step-by-step.

## Further steps for optimization (no implementation planned)
2. Separation: Tool assignment phase as pre-search phase.

3. A*: Reduction in the search domain with the A* Algorithm.
- Use domain specific heuristics to accelerate search.  

Step 2. and 3. most certainly are not needed, because the brute force search is sufficient. 

 


