Meteor.publish('article', (slug) => Articles.find({ slug }, {
  fields: {
    title: 1,
    description: 1,
    body: 1,
    createdAt: 1,
    createdBy: 1,
    slug: 1,
    favorites: 1,
    tagList: 1,
  },
  sort: { createdAt: -1 },
  limit: 1,
}));

Meteor.publish('comments', (_id) => Comments.find({ articleId: _id }, { fields: { createdBy: 1, createdAt: 1, body: 1 } }));

Meteor.publish('author', (_id) => Meteor.users.find({ _id }, { fields: { profile: 1, username: 1 } }));


Meteor.publish('profileArticles', function (filter, offset) {
  check(filter, {
    username: String,
    favorites: Boolean,
  });
  check(offset, Number);

  const user = Meteor.users.findOne({ username: filter.username }, { fields: { _id: 1 } });
  if (!user) return this.ready();

  return Articles.find({ [filter.favorites ? 'favorites' : 'createdBy']: user._id }, {
    fields: {
      title: 1,
      description: 1,
      body: 1,
      createdAt: 1,
      createdBy: 1,
      slug: 1,
      favorites: 1,
      tagList: 1,
    },
    sort: { createdAt: -1 },
    skip: offset,
    limit: 20,
  });
});


Meteor.publish('articles', function (feed, offset) {
  check(feed, String);
  check(offset, Number);

  // default is global feed
  const selector = {};

  if (feed === 'mine') {
    if (!this.userId) return this.ready();
    selector.createdBy = { $in: Meteor.users.find({ 'profile.followerIds': this.userId }).map((u) => u._id) };
  } else if (feed !== 'global') {
    // it's a tag
    selector.tagList = feed;
  }

  return Articles.find(selector, {
    fields: {
      title: 1,
      description: 1,
      body: 1,
      createdAt: 1,
      createdBy: 1,
      slug: 1,
      favorites: 1,
      tagList: 1,
    },
    sort: { createdAt: -1 },
    skip: offset,
    limit: 20,
  });
});
