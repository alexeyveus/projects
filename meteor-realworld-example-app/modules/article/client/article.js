import { marked } from 'marked';

Template.article.onCreated(function () {
  this.autorun(() => {
    // watch path change to trigger autorun
    FlowRouter.watchPathChange();

    this.subscribe('article', FlowRouter.getParam('slug'), () => {
      const article = Articles.findOne({ slug: FlowRouter.getParam('slug') });
      if (!article) return;

      this.subscribe('comments', article._id);
    });
  });
});


Template.article.helpers({
  article() { return Articles.findOne({ slug: FlowRouter.getParam('slug') }); },
  marked(body) { return marked(body); },
  comments() { return Comments.find({}, { sort: { createdAt: -1 } }).fetch(); },
});

Template.article.events({
  'submit form'(event) {
    event.preventDefault();

    const textarea = event.currentTarget.comment;
    Comments.add(textarea.value);
    textarea.value = '';
  },
});

Template.articleMeta.onCreated(function () {
  this.autorun(() => {
    const article = Template.currentData();
    if (article) this.subscribe('author', article.createdBy);
  });
});


Template.articleMeta.events({
  'click .js-article-favorite'() {
    Articles.findOne(this._id).favoriteToggle();
  },
  'click .js-article-delete'() {
    Articles.remove(this._id);
    FlowRouter.go('home');
  },
  'click .js-author-favorite'() {
    Meteor.call('userFollow');
  },
});

Template.comment.onCreated(function () {
  this.autorun(() => {
    const comment = Template.currentData();
    if (comment) this.subscribe('author', comment.createdBy);
  });
});


Template.comment.events({
  'click .js-comment-delete'() {
    Comments.remove(this._id);
  },
});
