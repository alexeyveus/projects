Template.settings.onCreated(function settingsOnCreated() {
  this.update = new ReactiveVar({});
  this.errors = new ReactiveVar([]);
});

Template.settings.helpers({
  emailAddress() { return Meteor.user()?.emails?.[0]?.address; },
});

const updatePassword = (oldPassword, newPassword) => new Promise((resolve, reject) => {
  Accounts.changePassword(oldPassword, newPassword, (err) => {
    if (err) reject(err);
    else resolve();
  });
});

const asyncMethods = (method, ...args) => new Promise((resolve, reject) => {
  Meteor.call(method, ...args, (err, result) => {
    if (err) reject(err);
    else resolve(result);
  });
});

Template.settings.events({
  'change input, change textarea': function changeInput(event, instance) {
    const el = event.currentTarget;
    const formData = instance.update.get();
    formData[el.name] = el.value;

    instance.update.set(formData);
  },
  'submit form': async function submitForm(event, instance) {
    event.preventDefault();

    const update = instance.update.get();
    const errors = [];

    // password
    if (update.newPassword && update.oldPassword) {
      try {
        await updatePassword(update.oldPassword, update.newPassword);
      } catch (err) {
        errors.push(...err.details);
      }
    } else if (update.newPassword) {
      errors.push({ message: 'Old password is mandatory to update your password' });
    }

    // clean data as they will be used in user profile update.
    delete update.oldPassword;
    delete update.newPassword;

    // profile
    if (['username', 'bio', 'email', 'picture'].find((field) => field in update)) {
      try {
        await asyncMethods('userUpdate', update);
      } catch (err) {
        errors.push({ message: err.reason });
      }
    }

    instance.errors.set(errors);
  },
});
