Articles = new Meteor.Collection('articles');

Articles.helpers({
  isFavorited() { return this.favorites?.includes(Meteor.userId()); },
  author() { return Meteor.users.findOne(this.createdBy); },
  isAuthor() { return this.createdBy === Meteor.userId(); },

  favoriteToggle() {
    const userId = Meteor.userId();
    if (!userId) return;
    const isFavorited = this.favorites?.includes(userId);
    Articles.update(this._id, { [isFavorited ? '$pull' : '$addToSet']: { favorites: userId } });
  },
});

Meteor.users.helpers({
  following() { return this.profile?.followerIds?.includes(Meteor.userId()) ?? false; },
  picture() { return this.profile?.picture || 'https://static.productionready.io/images/smiley-cyrus.jpg'; },
});


Comments = new Meteor.Collection('comments');

Comments.helpers({
  author() { return Meteor.users.findOne(this.createdBy); },
  isAuthor() { return this.createdBy === Meteor.userId(); },
});

Comments.add = (body) => {
  if (!body) return;

  const userId = Meteor.userId();
  if (!userId) return;

  const article = Articles.findOne({ slug: FlowRouter.getParam('slug') });
  if (!article) return;

  Comments.insert({
    createdBy: userId, createdAt: new Date(), articleId: article._id, body,
  });
};
