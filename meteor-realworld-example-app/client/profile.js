Template.profile.onCreated(function profileOnCreated() {
  this.offset = new ReactiveVar(0);

  this.autorun(() => {
    FlowRouter.watchPathChange();
    this.subscribe('profile', FlowRouter.getParam('username'));
    this.offset.set(0);
  });

  this.autorun(() => {
    FlowRouter.watchPathChange();
    this.subscribe('profileArticles', { username: FlowRouter.getParam('username'), favorites: FlowRouter.getRouteName() === 'profileFavorites' }, this.offset.get());
  });
});

Template.profile.helpers({
  user() {
    return Meteor.users.findOne({ username: FlowRouter.getParam('username') });
  },
  articles() {
    return Articles.find({});
  },
});

Template.profile.events({
  'click .js-user-follow'() {
    const user = Meteor.users.findOne({ username: FlowRouter.getParam('username') });
    Meteor.call('userFollow', user._id);
  },
  'click .js-offset-update'(event, instance) {
    event.preventDefault();
    instance.offset.set(instance.offset.get() + +event.currentTarget.dataset.offset);
  },
});
