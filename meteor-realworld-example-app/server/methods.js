Meteor.methods({
  userUpdate(update) {
    const { userId } = this;

    // user is not authenticated.
    if (!userId) return;

    check(update, {
      username: Match.Optional(String),
      bio: Match.Optional(String),
      picture: Match.Optional(String),
      email: Match.Optional(String),
    });

    const {
      username,
      bio,
      picture,
      email,
    } = update;

    // update username
    if (username === '') throw new Meteor.Error('invalid-username', 'Username can\'t be empty');
    if (username) Accounts.setUsername(userId, username);

    // update profile with bio and or picture
    const $set = {};

    if (('bio' in update)) $set['profile.bio'] = bio;
    if (('picture' in update)) $set['profile.picture'] = picture;

    if (Object.keys($set).length) Meteor.users.update(userId, { $set });

    if (email) {
      const actualEmail = Meteor.user().emails?.[0]?.address;
      Accounts.addEmail(userId, email);
      if (actualEmail) Accounts.removeEmail(userId, actualEmail);
    }
  },
  userFollow(userId) {
    if (!this.userId) return;

    check(userId, String);

    const unFollow = Meteor.users.findOne(userId).following();
    Meteor.users.update(userId, { [unFollow ? '$pull' : '$addToSet']: { 'profile.followerIds': this.userId } });
  },
  popularTags() {
    return Articles.rawCollection().aggregate([{ $unwind: '$tagList' }, { $sortByCount: '$tagList' }, { $limit: 20 }]).map((tag) => tag._id).toArray();
  },
});
