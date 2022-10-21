Meteor.publish('profile', (username) => {
  check(username, String);
  return Meteor.users.find({ username }, { fields: { profile: 1, username: 1 } });
});
