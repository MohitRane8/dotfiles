# Customizing a fresh install of Firefox
1. Right the side of the address bar and click `Customize Toolbar`.
2. Remove everything from the toolbar except back/forward buttons, address bar, extensions and menu buttons.
3. Go to `about:config`.
4. Search `toolkit.legacyUserProfileCustomizations.stylesheets` and set its state to true.
5. Go to `about:profiles`.
6. Find your profile  --  ( *„This is the profile in use and it cannot be deleted.”* )
7. Open the profile's root directory
8. Create `chrome` directory and place files in that directory.
9. Restart Firefox