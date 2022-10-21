import SimpleSchema from 'simpl-schema';

SimpleSchema.defineValidationErrorTransform((error) => {
  const ddpError = new Meteor.Error(error.message);
  ddpError.error = 'validation-error';
  ddpError.details = error.details;
  return ddpError;
});
validates = {
  register: new SimpleSchema({
    username: { type: String, min: 3 },
    email: { type: String, min: 3 },
    password: { type: String, min: 8 },
  }),
  newUser: new SimpleSchema({
    _id: String,
    username: { type: String, min: 3 },
    emails: Array,
    'emails.$': Object,
    'emails.$.address': String,
    'emails.$.verified': Boolean,
    createdAt: Date,
    services: { type: Object, blackbox: true },
  }),
};
