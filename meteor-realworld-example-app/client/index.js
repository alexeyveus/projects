Template.header.helpers({
  isCurrentUserProfile() {
    return FlowRouter.getParam('username') === Meteor.user().username;
  },
});

Template.home.onCreated(function () {
  this.feed = new ReactiveVar('global');
  this.offset = new ReactiveVar(0);

  this.autorun(() => {
    this.subscribe('articles', this.feed.get(), this.offset.get());
  });

  this.popularTags = new ReactiveVar([]);
  Meteor.call('popularTags', (err, popularTags) => { this.popularTags.set(popularTags); });
});

Template.home.helpers({
  articles() { return Articles.find({}, { sort: { createdAt: -1 } }); },
  isFeedTag() { return ['global', 'mine'].every((feed) => feed !== Template.instance().feed.get()); },
});

Template.home.events({
  'click .js-home-feed'(event, instance) {
    event.preventDefault();

    instance.feed.set(event.currentTarget.dataset.feed);
  },
  'click .js-offset-update'(event, instance) {
    event.preventDefault();
    instance.offset.set(instance.offset.get() + +event.currentTarget.dataset.offset);
  },
});
