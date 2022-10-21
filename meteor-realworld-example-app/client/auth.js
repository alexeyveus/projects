Template.register.onCreated(function registerOnCreated() {
  this.errors = new ReactiveVar([]);
});

const formValueToOptions = (src, opts, name) => ({ ...opts, [name]: src[name].value });

Template.register.events({
  'submit form': function submitForm(event, instance) {
    const options = ['username', 'email', 'password'].reduce(formValueToOptions.bind(null, event.currentTarget), {});

    try {
      validates.register.validate(options);
    } catch (err) {
      instance.errors.set(err.details);
      return false;
    }

    Accounts.createUser(options, (err) => {
      if (err) instance.errors.set(err.details);
      else FlowRouter.go('home');
    });

    return false;
  },
});


Template.login.onCreated(function loginOnCreated() {
  this.error = new ReactiveVar();
});

Template.login.events({
  'submit form': function submitForm(event, instance) {
    const options = ['email', 'password'].reduce(formValueToOptions.bind(null, event.currentTarget), {});
    Meteor.loginWithPassword(options.email, options.password, (err) => {
      if (err) instance.error.set(err);
      else FlowRouter.go('home');
    });

    return false;
  },
});
