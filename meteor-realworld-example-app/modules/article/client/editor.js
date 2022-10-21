import generateSlug from 'slug';

Template.editor.onCreated(function () {
  this.tagList = new ReactiveVar([]);
  const errors = new ReactiveVar([]);

  this.errors = {
    list() { return errors.get(); },
    add(error) {
      const errorsList = errors.get();
      if (errorsList.includes(error)) return;

      errorsList.push(error);
      errors.set(errorsList);
    },
    remove(error) {
      const errorsList = errors.get();

      const index = errorsList.indexOf(error);
      if (index === -1) return;

      errorsList.splice(index, 1);
      errors.set(errorsList);
    },
    clear() { errors.set([]); },
  };

  const slug = FlowRouter.getParam('slug');
  if (slug) {
    this.subscribe('article', slug, () => {
      const article = Articles.findOne({ slug: FlowRouter.getParam('slug') });
      const tagList = article.tagList || [];
      this.tagList.set(tagList);
    });
  }
});

Template.editor.helpers({
  article() { return Articles.findOne({ slug: FlowRouter.getParam('slug') }); },
});

Template.editor.events({
  'change input[name=tag]'(event, instance) {
    event.preventDefault();

    const el = event.target;
    const tag = el.value;
    const tagList = instance.tagList.get();

    const tagError = 'Tags already added';
    if (tagList.includes(tag)) { instance.errors.add(tagError); return; }
    instance.errors.remove(tagError);

    if (!tag) return;

    tagList.push(tag);
    instance.tagList.set(tagList);
    el.value = '';
  },
  'click .js-tags-remove'(event, instance) {
    const tags = instance.tagList.get();
    tags.splice(tags.indexOf(this), 1);
    instance.tagList.set(tags);
  },
  'click button'(event, instance) {
    event.preventDefault();

    const { form } = event.currentTarget;

    const title = form.title.value;
    const description = form.description.value;
    const body = form.body.value;
    const tagList = instance.tagList.get();

    instance.errors[title ? 'remove' : 'add']('Title is required');
    instance.errors[description ? 'remove' : 'add']('description is required');
    instance.errors[body ? 'remove' : 'add']('body is required');

    if (instance.errors.list().length) return;

    const article = {
      slug: FlowRouter.getParam('slug'),
      title,
      description,
      body,
      tagList,
      updatedAt: new Date(),
    };

    if (article.slug) {
      const articleId = Articles.findOne({ slug: FlowRouter.getParam('slug') })._id;
      if (articleId) Articles.update(articleId, { $set: article });
    } else {
      article.slug = `${generateSlug(title)}-${Random.id(6).toLowerCase()}`;
      article.createdAt = new Date();
      article.createdBy = Meteor.userId();

      Articles.insert(article);
    }

    FlowRouter.go('article', { slug: article.slug });
  },
});
