# Screenshots
<p float="left">
    <img src="https://i.imgur.com/tEdITV0.png" width=400 />
    <img src="https://i.imgur.com/kiAUsFz.png" width=400 />
</p>

# Remarks

- I spent about 6 hours on the task
- My biggest focus was getting the UI pixel perfect
- Values in right side of Displayed Currency cells are confusing
- I didn't import the custom font used in the Figma. Font sizes are hard-coded and will NOT scale for accessibility
- The max button is too close to the fiat type selection button, should be more explicit that it's tappable
- The info label at the bottom of the Displayed Currency shouldn't be styled so similarly to the cells, it's too close to the selected state for the currency types
- Dark background behind Displayed Currency when presented is not standard iOS UI
- Drag indicator at top of Displayed Currency is not standard iOS UI
- Weird captialization: "Est. Network fees: ~..." 
- Does it need to say "Est" and have "~" next to value?
- Max button's currency should correspond with selected currency. Figma shows ETH value next to max, but updates value below editable textField when displayed? I'm confused...
- I made assumptions about how to position the RootView's content when the keyboard is dimissed as it's not shown. Figma would lead me to believe title + conversion view are pushed to top with send button all the way at the bottom. This is bad UX leaving a big white space and making the user reach the top of the screen for view's primary functionality.

# If I were to spend more time...

- More atomic commits, these would be a pain to review and not how I like to work
- More unit testing
- Implement user model to store user info, authentication
- Split views into separate files for better re-usability, get rid of ugly nested ternaries
- Add custom fonts
- Dark mode?
- Have a chat with the designer
