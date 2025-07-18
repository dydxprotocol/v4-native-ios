import { StyleSheet } from 'react-native';

export const styles = StyleSheet.create({
  container: {
    flexGrow: 1,
    backgroundColor: '#1c1c1e',
    padding: 20,
    justifyContent: 'center',
  },
  title: {
    fontSize: 24,
    color: '#fff',
    fontWeight: '600',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 14,
    color: '#aaa',
    marginBottom: 24,
  },
  socialRow: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    marginBottom: 20,
  },
  socialButton: {
    backgroundColor: '#2c2c2e',
    borderRadius: 8,
    padding: 12,
  },
  emailRow: {
    flexDirection: 'row',
    backgroundColor: '#2c2c2e',
    borderRadius: 8,
    overflow: 'hidden',
    marginBottom: 24,
  },
  emailInput: {
    flex: 1,
    paddingHorizontal: 12,
    color: '#fff',
  },
  submitButton: {
    backgroundColor: '#3a3a3c',
    justifyContent: 'center',
    paddingHorizontal: 12,
  },
  submitButtonText: {
    color: '#fff',
    fontWeight: '500',
  },
  dividerContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 24,
  },
  divider: {
    flex: 1,
    height: 1,
    backgroundColor: '#333',
  },
  dividerText: {
    color: '#888',
    marginHorizontal: 8,
  },
  actionButton: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#2c2c2e',
    borderRadius: 8,
    padding: 14,
    marginBottom: 12,
  },
  actionButtonText: {
    color: '#fff',
    fontSize: 16,
  },
});
