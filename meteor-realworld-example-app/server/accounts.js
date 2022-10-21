// Ensuring every user has an email address, should be in server-side code
Accounts.validateNewUser((user) => {
  validates.newUser.validate(user);

  // Return true to allow user creation to proceed
  return true;
});
